# traefik-rock

Automation for building a ROCK for Traefik. Every fourth hour, the automation checks whether 
a new release has been cut in the upstream Traefik repo, and if so, creates a pull request with 
the new version info.

Once the PR gets merged, a new ROCK is built and published on ghcr.io/canonical/traefik.
