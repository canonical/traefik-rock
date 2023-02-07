# traefik-rock

Automation for building a ROCK for Traefik. Every fourth hour, the automation checks whether 
a new release has been cut in the upstream Traefik repo, and if so, creates a pull request with 
the new version info.

Once the PR gets merged, a new ROCK is built and published on ghcr.io/canonical/traefik.



# Manual verification:

`rockcraft -v`
`docker import ./traefik_2.9.6_amd64.rock trfk`
`docker run  --rm -d -p 8080:8080 trfk`

cleanup:
`docker rmi trfk`