# Evolune Web

Independent public website for Evolune, a local-first Android and Wear OS application.

## Pages

- `/` — application homepage
- `/privacy/` — Privacy Policy
- `/terms/` — Terms of Service

The site is intentionally plain HTML and CSS so it can be audited, hosted anywhere, and served without a build step, database, analytics, cookies, or login.

## Deployment

Pushes to `main` are rsynced to the VPS by `.github/workflows/deploy.yml` (target `/var/www/evolune`, served by Caddy at `evolune.yingqiu.me` behind Cloudflare). Server and Caddy setup live in the `yuning-gu.github.io` repository under `deploy/`.

Required repository secrets: `DEPLOY_HOST`, `DEPLOY_USER` (`deployer`), `DEPLOY_SSH_KEY`, optional `DEPLOY_PORT`. Optional variable `DEPLOY_PATH` overrides the target directory.

The website was previously hosted on GitHub Pages; the `CNAME` file is a leftover and is not deployed.

Support contact: guyuning2002@gmail.com

The product license source is the MIT License in the Evolune Android repository: https://github.com/YingQiu0871/Evolune
