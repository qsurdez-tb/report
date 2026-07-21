= Deployment : implementation details <appendix-deployment>

CI and configuration listings for the deployment chapter (@deployment).

== Build repository CI (`docker/.gitlab-ci.yml`)

#figure(
  ```yaml
  before_script:
      - echo "__branch__ = '${CI_COMMIT_REF_NAME}'"        >  ./web/app/version.py
      - echo "__commit__ = '${CI_COMMIT_SHA}'"             >> ./web/app/version.py
      - echo "__commitshort__ = '${CI_COMMIT_SHORT_SHA}'"  >> ./web/app/version.py
      - echo "__commiturl__ = '${CI_PROJECT_URL}/commit/${CI_COMMIT_SHA}'" >> ./web/app/version.py
      - echo "__date__ = '${CI_COMMIT_TIMESTAMP}'"         >> ./web/app/version.py
      - echo "__version__ = ' - '.join( [ __commitshort__, __date__ ] )"  >> ./web/app/version.py
      - echo "__author_name__ = '${GITLAB_USER_NAME}'"     >> ./web/app/version.py
      - echo "__author_email__ = '${GITLAB_USER_EMAIL}'"   >> ./web/app/version.py
  ```,
  caption: [Baking the build's provenance (branch, commit, author, date) into `version.py`, which the login page displays.]
)

#figure(
  ```yaml
  - mkdir -p /kaniko/.docker
  - echo "{\"auths\":{\"$CI_REGISTRY\":{\"auth\":\"$(echo -n $CI_REGISTRY_USER:$CI_REGISTRY_PASSWORD | base64)\"}}}" > /kaniko/.docker/config.json
  ```,
  caption: [Kaniko registry authentication, written from the GitLab CI credentials.]
)

== Configuration repository CI (`conf/production/.gitlab-ci.yml`)

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
  caption: [The configuration repository pipeline installs the Docker CLI and runs `make`.]
)

#figure(
  ```makefile
  template:
      cat docker-compose.yml.template | envsubst > docker-compose.yml

  deploy:
      docker -H ${HOST} stack deploy -c docker-compose.yml icnml

  clean:
      -rm ${CONFIGURATION}
  ```,
  caption: [The production `Makefile`: fill the template with `envsubst` @envsubst-doc, deploy to the remote Swarm manager (`-H ${HOST}`) @dockerD-doc, then remove the runtime env file.]
)
