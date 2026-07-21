#import "../macros.typ": note, concept

= Deployment <deployment>

#concept[
  ICNML is deployed through a fully automated pipeline. A developer pushes code, and, with no manual step, new images are built and rolled out to a production cluster. This chapter documents that pipeline as it was originally designed, the state it was in when this thesis began. It predates the Python 3 migration and, as of writing, no longer runs, broken by two independent failures covered at the end. The production version of ICNML is also down as of writing. The verbose CI and configuration listings are in @appendix-deployment.
]

The pipeline follows a GitOps pattern, meaning a Git repository, not a person, is the source of truth for what runs in production. A change is made by committing, and automation reconciles the running system to match the new version of the code. @deploy-seq-fig shows the full sequence, from a developer's push to a live update on the cluster.

#figure(
  image("../assets/deployment-sequence.drawio.png", width: 63%),
  caption: [The deployment sequence: a push builds images and, through a second repository, rolls them out to the production Swarm.],
)<deploy-seq-fig>

== The two-repository chain

Deployment spans two Git repositories with distinct roles.

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Repository][Role],
    [`ICNML/docker`], [The build side: the Flask application (with its libraries as submodules) and the build pipeline. A developer updates the submodule references here to update the project.],
    [`ICNML/conf/production`], [The deploy side: holds the `docker-compose` template describing the production stack. Commits to its `master` branch trigger the actual deployment.],
  ),
  caption: [The two repositories in the deployment chain.],
)

A push to `master` in the build repository starts the first pipeline. Its final step commits a change to the configuration repository, which triggers the second pipeline. After the initial push, no manual intervention is needed.

== Building the image

The build pipeline uses Kaniko, a tool that builds Docker images from inside an unprivileged container without needing a privileged runner. Before every job it clones all submodules (the web app and its `WSQ`, `MDmisc`, `NIST`, `PMlib` dependencies), then runs a preparation step that inserts the build's provenance into the image, copies the GPG keys into the build context, and authenticates to the registry (@appendix-deployment).

The build produces different image tags depending on the branch, so a feature branch can be built and pulled without disturbing production:

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Job][Branches][Tags pushed],
    [`web_dev`, `redis_dev`],       [all except `master`], [`<short-sha>`, `<branch-name>`],
    [`web_master`, `redis_master`], [`master` only],       [`<short-sha>`, `master`, `latest`],
  ),
  caption: [Build jobs and their image tags. Only `master` builds update the `latest` tag.],
)

On `master`, once the images are built, a deploy job hands off to the configuration repository. It does not deploy directly. Instead it clones the configuration repository over SSH, rewrites the `web` image tag in the compose template to the exact commit just built, and commits that change back. Pinning the deployment to a specific commit SHA, and attributing the automated commit to the developer who triggered it, gives a traceable history from any production state back to the source change that produced it.

== Deploying to the cluster

The commit into the configuration repository triggers its own pipeline, which installs the Docker CLI and runs a `Makefile` (@appendix-deployment). That `Makefile` fills the compose template with the runtime environment values, then runs `docker stack deploy` against the remote production Swarm manager. The production stack is a Docker Swarm of two services:

#figure(
  table(
    columns: (auto, auto, auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, center, center, left),
    table.header[Service][Image][Replicas][Memory][Notes],
    [`web`],   [`.../web:<sha>`],     [15], [512 MB], [Pinned to the deploying commit],
    [`redis`], [`.../redis:latest`],  [1],  [1 GB],  [Always the latest master build],
  ),
  caption: [The production Swarm services.],
)

Running the web service in fifteen replicas is what allows updates to be rolled out gradually rather than all at once. The update policy starts five new replicas at a time, waits for each to pass a health check before stopping its old counterpart (`start-first`), and, if an update fails, automatically rolls every replica back to the previous image. In principle, a bad deploy repairs itself.

== Why it no longer runs <pipeline-status>

The pipeline is currently broken by two independent failures, either of which alone would stop it.

/ First, the submodule URLs return 404 : The build clones the `WSQ`, `MDmisc`, `NIST` and `PMlib` libraries as submodules before any job runs, and all four remotes are now unreachable. Because this happens at the very first step, no job runs at all, which is also why a new environment cannot be built from the repositories alone (@appendix-dev-env).

/ Second, the registry certificate is invalid : Kaniko cannot push images to `cr.unil.ch` because the server presents a certificate issued for a different host. Even with the submodules fixed, every image push would still be rejected. Together, these mean no developer can currently build or deploy ICNML through the automated pipeline.

== Assessment

As a design, the pipeline is genuinely good. Fully automated GitOps with the configuration repository as the source of truth, commit-pinned deployments traceable back to their source change, and health-checked rolling updates with automatic rollback are all production-grade practices that many mature projects lack.

Its fragility is operational, not architectural, and it is severe. The pipeline depends on external submodule remotes and a container registry that have both become unreachable, so it is currently inert, and it is built on Kaniko, which has since been archived. Because the Python 3 migration also changed how the application is built, this original pipeline cannot simply be repaired in place, it needs to be re-established around the new stack. Documenting the migration (@python3-migration) and rebuilding a working, submodule-free deployment on maintained tooling is the natural continuation of this chapter.
