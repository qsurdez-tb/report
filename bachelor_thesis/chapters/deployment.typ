#import "../macros.typ": note

= Deployment

This chapter documents the deployment pipeline and production infrastructure of ICNML. The pipeline follows a GitOps patter: a push to the `master` branch in the source repository triggers an image builds and then propagates a configuration change to a dedicated configuration production repository. Another pipeline in the configuration production repository will do the actual deployment on a Docker Swarm cluster. 

As of the time of writing, this pipeline is no longer operational. Two independent failures prevent it from completing. First, The external library submodules it depends on are unreachable. Second, the container registry has an invalid TLS certificate. Further discussed in @pipeline-status

== Repositories involved

Two separate Git repositories are involved in the deployment: 

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Repository][Role],
    [`esc-md-git.unil.ch/ICNML/docker`],      [Docker repository for deployment. Contains the Flask application, libraries as submodules and the build pipeline (`.gitlab-ci.yml`). This is where the dev update the commit reference of the submodules to update the project.],
    [`esc-md-git.unil.ch/ICNML/conf/production`], [Production configuration repository. Holds the `docker-compose.yml.template` that describes the production stack. Commits to its `master` branch trigger the deployment pipeline.],
  ),
  caption: [The two repositories involved in the deployment chain]
)

A push to `master` in the docker repository initiates the first pipeline. That pipeline's final step commits a change to the configuration repository, which launches the second pipeline. Neither pipeline requires manual intervention after the initial push.

== Docker Repository Pipeline

The docker repository's pipeline (`.gitlab-ci.yml`) defines two stages: `build` and `deploy`.

=== Default Image and Submodules

The build job in the pipeline runs inside the Kaniko executor image (`gcr.io/kaniko-project/executor:debug`), the deploy job runs on the base icnml image (`cr.unil.ch/icnml/base:latest`). Kaniko builds Docker images from inside an unprivileged container, without requiring Docker-in-Dcoker or a privileged runner. The Kaniko project has since been archived and is no longer maintained, which is a concern for the maintenance of the pipeline.

The variable `GIT_SUBMODULE_STRATEGY: recursive` causes GitLab CI to clone all submodules before each script or before_script. This ensures the web application and its dependencies are present in the build context. 

#note[Today, the urls for the WSQ, MDmisc, NIST and PMlib, return a 404. This means that the pipeline is broken today.]

#note[Today, the pipeline fails with this error: tls: failed to verify certificate: x509: certificate is valid for bunny.unil.ch, not cr.unil.ch. This has been written about in the dev setup environment.]

=== Before Script

A `before_script` block runs before every job in the pipeline. It performs three tasks. 

First, it generates `web/app/version.py` by echoing Python assignments for the following GitLab variables: 

#figure(
  ```yaml
  before_script:
      - echo "__branch__ = '${CI_COMMIT_REF_NAME}'"     >  ./web/app/version.py
      - echo "__commit__ = '${CI_COMMIT_SHA}'"          >> ./web/app/version.py
      - echo "__commitshort__ = '${CI_COMMIT_SHORT_SHA}'" >> ./web/app/version.py
      - echo "__commiturl__ = '${CI_PROJECT_URL}/commit/${CI_COMMIT_SHA}'" >> ./web/app/version.py
      - echo "__treeurl__ = '${CI_PROJECT_URL}/tree/${CI_COMMIT_SHA}'"     >> ./web/app/version.py
      - echo "__date__ = '${CI_COMMIT_TIMESTAMP}'"       >> ./web/app/version.py
      - echo "__version__ = ' - '.join( [ __commitshort__, __date__ ] )"   >> ./web/app/version.py
      - echo "__author_name__ = '${GITLAB_USER_NAME}'"  >> ./web/app/version.py
      - echo "__author_email__ = '${GITLAB_USER_EMAIL}'" >> ./web/app/version.py
      - echo "__author__ = __author_name__ + ' <' + __author_email__ + '>'" >> ./web/app/version.py
  ```,
  caption: [`version.py` generation in `before_script`]
)

This includes the build source with the branch, full and short commit SHA, commit and tree URLs, timestamp and author into the application image. 

Then, it copies the GPG keys from `./config/keys` into `./web/keys`, putting them in the Docker build context so the web image can inlcude them.

Third, it writes Kaniko's registry authentication file: 

#figure(
  ```yaml
  - mkdir -p /kaniko/.docker
  - echo "{\"auths\":{\"$CI_REGISTRY\":{\"auth\":\"$(echo -n $CI_REGISTRY_USER:$CI_REGISTRY_PASSWORD | base64)\"}}}" > /kaniko/.docker/config.json
  ```,
  caption: [Kaniko registry authentication setup]
)

The credentials are encoded with base64 from the GitLab CI predefined vairables `CI_REGISTRY_USER` and `CI_REGISTRY_PASSWORD`. 

=== Build Stage

The build stage conatins four jobs split in development deliverables or production.

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Job][Branches][Tags pushed],
    [`web_dev`],     [all except `master`], [`<short-sha>`, `<branch-name>`],
    [`redis_dev`],   [all except `master`], [`<short-sha>`, `<branch-name>`],
    [`web_master`],  [`master` only],       [`<short-sha>`, `master`, `latest`],
    [`redis_master`],[`master` only],       [`<short-sha>`, `master`, `latest`],
  ),
  caption: [Build jobs and their image tag outputs]
)

All four jobs call the Kaniko executor with `--cache=true --cache-ttl 20h`, that caches Docker layers for twenty hours across runs on the same runner. Each job builds one image and pushes it to the GitLab container registry under `$CI_REGISTRY_IMAGE`.

On branches that are not master, images are tagged with the commit short SHA and the branch name. This makes it possible to pull a specific branch's build without overwriting the `latest`tag. On `master`, a third `latest` tag is also pushed. This makes the most recent production build always reachable by that tag.

=== Deploy Stage

The deploy job runs only on `master` after both build jobs have completed. It uses `cr.unil.ch/icnml/base:latest`, which provides `git`, `ssh` and `openssh-client`.

The job does the following actions: 

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Step][Action],
    [1], [Start an `ssh-agent` and load the `$SSH_CONFIGURATION_KEY` secret variable into it.],
    [2], [Set the git user identity from the triggering commit's author name and email (via `git show`), so the automated commit in the config repo is attributed to the dev who pushed.],
    [3], [Scan and record the production git server's host key (`ssh-keyscan`) to prevent an interactive prompt.],
    [4], [Clone the production configuration repository into a temporary directory.],
    [5], [Rewrite the `web` image tag in `docker-compose.yml.template` from whatever value it held to `cr.unil.ch/icnml/docker/web:<short-sha>` using `sed`.],
    [6], [Commit the change and push to the configuration repository's `master` branch.],
    [7], [Clear the loaded SSH key and shut down the agent.],
  ),
  caption: [Deploy job steps]
)

The automated commit message records the short SHA and links back to the full commit in the source repository, providing an history from any production configuration state back to the changes from the Docker repository.

=== Current Pipeline Status <pipeline-status>

The pipeline is broken by two independent failures that both must be resolved before a build can succeed. 

First the submodule URLs returning 404. The build relies on `GIT_SUBMODULE_STRATEGY: recursive` to clone the external libraries WSQ, MDmisc, NIST and PMlib before any job. The URLs for all four of these submodules return a 404. Because GitLab CI fetches submodules before executing any script, the pipeline fails at the very first step and no job runs. This also means that setting up a new development environment from the repository alone is impossible. 

Second, the TLS certificate mismatch on the container registry. Kaniko fails to push images to `cr.unil.ch` because the server presents a certificate issued for `bunny.unil.ch` rather than `cr.unil.ch`. Even if the submodule issue was fixed, the build stage would complete but every push to the registry would be rejected. This issue was also encountered during the developement environment setup.

Together, these two failures mean that no developer can currently build or deploy ICNML through the automated pipeline.

== Production Configuration Repository Pipeline

When the docker repository's deploy job pushes to `mater` in the configuration repository, GitLab triggers the configuration repository's own pipeline:

#figure(
  ```yaml
  deploy:
      stage: deploy
      script:
          - apt update
          - apt install -y docker.io
          - make
      only:
          - master
  ```,
  caption: [Production configuration repository pipeline]
)

This job installs the Docker CLI and then calls `make`, which executes three commands: 

#figure(
  ```makefile
  template:
      cat docker-compose.yml.template | envsubst > docker-compose.yml

  deploy:
      docker -H ${HOST} stack deploy -c docker-compose.yml icnml

  clean:
      -rm ${CONFIGURATION}
  ```,
  caption: [Production `Makefile` (`icnml/production/Makefile`)]
)

The `template` command creates the `docker-compose.yml` file via the template and the `envsubst` @envsubst-doc command. This will inject the remaining shell variable references (e.g. `${CONFIGURATION}`, the path to the runtime envionment file) to create the final `docker-compose.yml`.

The `deploy` command calls `docker stack deploy` with a remote Docker daemon via the `-H ${HOST}` @dockerD-doc flag. This connect to the production Swarm manager. The stack is named `icnml`.

The `clean` command removes the `${CONFIGURATION}` file. The envionment file that was placed on the runner for the duration of this job.

== Production Docker Compose

The production `docker-compose.yml` is a Docker Swarm with 2 services:

#figure(
  table(
    columns: (auto, auto, auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, center, center, left),
    table.header[Service][Image][Replicas][Memory][Notes],
    [`web`],   [`cr.unil.ch/icnml/docker/web:<sha>`],   [15], [512 MB], [Pinned to the deploying commit's short SHA],
    [`redis`], [`cr.unil.ch/icnml/docker/redis:latest`], [1],  [1 GB],  [Always the most recent master build],
  ),
  caption: [Production stack services]
)

The services communicate over an overlay network with a fixed subnet (`10.254.252.0/24`). Redis data is persisted in a named volume. 

=== Update and Rollback Policy

Both services define an `update_config` block that controls how Swarm performs rolling updates. For the `web` service:

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Parameter][Value],
    [`parallelism`],    [5, update five replicas at a time],
    [`delay`],          [10 seconds between batches],
    [`order`],          [`start-first`, new replica starts and passes health check before old one stops],
    [`failure_action`], [`rollback`, on failure, revert all updated replicas to the previous image],
  ),
  caption: [`web` service update policy]
)

== Deployment summary

#figure(
  image("../assets/deployment-sequence.drawio.png"),
  caption: [Diagram of the sequence to deploy on production server]
)