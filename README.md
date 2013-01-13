# API For LOSS
> No DPD, not anymore.

## Setup
### Env Variables
These environment variables need to be set: 
* mongohq_username
* mongohq_password
* github_clientid
* github_clientsecret
(contact me for keys :)
### Server Setup
#### Clone Repo
```
git clone git@github.com:Martikos/Losi-API.git
cd Losi-API
npm install
```
#### Install Global Dependencies
```
npm install -g coffeescript
npm install -g foreman
```
## Run Server
```
foreman start
```

## Stack: 
* Node.js with Express, CoffeeScript
* MongoDB & Mongoose

