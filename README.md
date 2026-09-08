# TYPO3 13

TYPO3 publishes no official image, so this builds `php:8.3-apache` with the
required extensions and creates a Composer-based TYPO3 project into `./app`.

    docker compose up -d --build
    docker compose logs -f typo3   # first boot pulls the Composer project

With `AUTO_SETUP=1` (default) the site installs itself — no installer to click.

- Frontend: http://localhost:8087
- Backend:  http://localhost:8087/typo3 — `admin` / `Password1!Password1!`
- Adminer:  http://localhost:8187

## Web installer instead
Set `AUTO_SETUP=0` in `.env`, then `docker compose up -d`. The entrypoint drops a
`FIRST_INSTALL` file; go to http://localhost:8087/typo3/install.php and use host
`db`, database `typo3`, user `typo3`, password `typo3`.

## Common tasks

    docker compose exec typo3 composer require georgringer/news
    docker compose exec typo3 vendor/bin/typo3 cache:flush
    docker compose exec typo3 vendor/bin/typo3 extension:setup

## Notes
- TYPO3 enforces a minimum backend password length; keep it long in `.env`.
- The project lives in `./app` on the host, so you can edit it with your IDE.
- Reset everything: `docker compose down -v && rm -rf app && mkdir app`
