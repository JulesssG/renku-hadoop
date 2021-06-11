# Renku deployment

We deploy Renku with ![an existing instance of Gitlab](https://renkulab.io/gitlab/) with helm3 and Kubernetes. You’ll need access to a cluster for your deployment in the form of a Kubernetes config file. We describe below the procedure we used but don’t forget to check ![the official instructions](https://renku.readthedocs.io/en/latest/admin/index.html) as they are more complete:

    Configure Kubernetes to use your config file (for example by setting `KUBECONFIG=<PATH_TO_YOUR_CONFIG_FILE>` in your `.profile`).

    In your Gitlab instance, under `https://<your-gitlab-url>/profile/applications` , create an new application with all scopes checked except for sudo. Save the application ID and secret. You’ll need to specify the correct redirection URI for your application. Here are ours:

```
https://<deployment-main-url>/auth/realms/Renku/broker/renkulab/endpoint
https://<deployment-main-url>/api/auth/gitlab/token
https://<deployment-main-url>/api/auth/jupyterhub/token
https://<deployment-main-url>/jupyterhub/hub/oauth_callback
```

You need to generate the configuration file for your deployment. This is the `renku-values.yaml` file and it can be generated using a basic template and a script that you can download from here. Use the application ID and secret you just generated and specify the Gitlab instance you chose and the deployment domain (`https://<deployment-main-url>`).

Add the Renku helm repository with `helm repo add renku https://swissdatasciencecenter.github.io/helm-charts/`

Deploy Renku using:
 helm upgrade --install <deployment-name> renku/renku \
 --namespace <your-namespace> \
 -f renku-values.yaml \
 --timeout 1800s

In another terminal, you should be able to see the pods creating when running `kubectl -n <your-namespace> get pods`. If something go wrong during the deployment, your `renku-values.yaml` file most likely contain errors and you’ll need to double check the redirection URL and the paths in the file manually to debug it.

Once the deployment is successful you should be able to access it under your deployment main URL.

If you want to be able to login to Renku directly using Gitlab (recommended) you’ll need to configure you Gitlab instance as and identity provider:

    Go to `https://<deployment-main-url>/auth/` and login as admin to the administration console. The password is in your `renku-values.yaml` file under global → keycloak -> password → value.

    Create a new OpenID Connect v1.0 identity provider.

    File the required values. The alias so that the redirect URI match the one you used for your Gitlab application, authorization URL to `https://<gitlab-domain>/oauth/authorize`, token URL to `https://<gitlab-domain>/oauth/token`. Client ID and secret are again the values generated at step 1.

    Verify that it is working by login with your Gitlab account in your Renku deployment.
