# Evolune Web

Independent public website for Evolune, a local-first Android and Wear OS application.

## Pages

- `/` — application homepage
- `/privacy/` — Privacy Policy
- `/terms/` — Terms of Service

The site is intentionally plain HTML and CSS so it can be audited, hosted on GitHub Pages, and served without a build step, database, analytics, cookies, or login.

## Deployment

GitHub Pages is configured through `.github/workflows/deploy-pages.yml`. The custom domain is recorded in `CNAME` as `evolune.yingqiu.me`.

Before Google OAuth verification, confirm that the GitHub Pages custom-domain setting is active and that the `evolune.yingqiu.me` DNS record points to the GitHub Pages hostname shown by GitHub for this repository.

Support contact: guyuning2002@gmail.com

The product license source is the MIT License in the Evolune Android repository: https://github.com/YingQiu0871/Evolune
