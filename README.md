# Personal Website

This is the source code of my personal website: <https://ferrarimarco.info>

## Development Environment

### Dependencies

- Docker 1.12+
- GNU Make

### How to Run

See the available Make targets by running: `make help`

When serving the website, open your browser pointing to `http://<ip>:3000` to see the website (with BrowserSync support)
and `http://<ip>:3001` to see the BrowserSync control panel.

An automated CI/CD pipeline is in charge of deploying the contents of the `dist` directory in production on each commit
to the master branch.
