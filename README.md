# shortener-web-v

Backend for a simple url shortener and plaintext + temporary binary store using vweb and Redis. Frontend is created using typescript and built using vite.

[**Shortener website here! (s.l-m.dev)**](https://s.l-m.dev/)

[**API docs here! (blog.l-m.dev)**](https://blog.l-m.dev/API-DOCS-for-s-l-m-dev-4abb3b502bf34a2ebbb5261b8d4a36d4)

### Requires
- V install
- NPM
- Redis with default configuration

## Compiling and running your own instance
**Inside the main directory...**

### Running the project for development
```sh
fuser -k 8080/tcp # kill process on 8080 port
v watch --add "templates/" run .
```
### Build simple binary
```sh
v up
sudo systemctl enable redis

cd public
npm install
cd ..
  # correct setup of all deps
  # npm deps for build
  # v updates
  # enable redis

./build/build-all.sh
  # this will build the vite project
  # then build the v binary after moving the correct files
./shortener-web-app
```
### Build tar.gz package
```sh
# install deps ....

./build/package.sh
  # creates shortener-all.tar.gz
```
