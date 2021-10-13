"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const realm_1 = __importDefault(require("realm"));
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = __importDefault(require("path"));
const realm_module_1 = require("./modules/realm_module");
const express = require('express');
// for flutter use the cors is absolutely required
const cors = require('cors');
// initialize configuration
dotenv_1.default.config();
const id = String(process.env.REALM_ID);
// host and port are now available to the Node.js runtime
// as if it were an environment variable
const port = process.env.SERVER_PORT;
const host = process.env.HOST;
const app = express();
let user;
// Configure Express to use EJS altough not needed for this project yet...
app.set("views", path_1.default.join(__dirname, "views"));
app.set("view engine", "ejs");
// CORS is needed for the android and ios client
app.use(cors());
// define a route handler for the default home page
app.get("/", (req, res) => {
    // render the index template using ejs
    res.render("index");
});
const config = {
    id,
};
let realmService;
const realm = new realm_1.default.App(config);
// Use a Realm token for authentication kept in the .env
const key = String(process.env.API_KEY);
const credentials = realm_1.default.Credentials.userApiKey(key);
const myPromise = new Promise((resolve, reject) => {
    try {
        setTimeout(() => {
            resolve(realm.logIn(credentials));
        }, 3000);
    }
    catch (e) {
        reject("Login failed");
        console.log("Did not complete request for login");
    }
});
//  use the User object to initiate the RealmServices
const service = new Promise((resolve, reject) => {
    try {
        myPromise.then((value) => {
            user = value;
            const _service = new realm_module_1.RealmServices(user);
            realmService = _service;
            resolve(_service);
        }).catch(err => {
            console.log("Promise failed");
            reject(err);
        });
    }
    catch (err2) {
        console.log("error: ", err2);
    }
});
function getService() {
    if (realmService)
        return realmService;
    service.then((s) => {
        realmService = s;
    });
    return realmService;
}
//   byNeighborhood is exposed as a GET method.  It returns JSON
app.get("/byNeighborhood", (req, res) => {
    const neighborhood = req.query.name;
    const cuisines = req.query.cuisines;
    try {
        let obj = getService().getByNeighborhood(neighborhood, cuisines);
        obj.then((o) => {
            if (o) {
                console.log("Call to REST completed: " + neighborhood + ' ' + cuisines);
                // Not needed but does give a visual indication of an http call successfully completing
                // console.log('Result: ' + JSON.stringify(o));
                res.send(o);
            }
            else {
                console.log("No value found");
                res.send({ "message": "no data" });
            }
        });
    }
    catch (e2) {
        console.log(e2);
    }
});
app.get('/byCuisine', (req, res) => {
    const limit = req.query.limit;
    console.log("Calling getRestaurantTypes");
    try {
        let obj = getService().getRestaurantTypes(limit);
        obj.then((o) => {
            if (o) {
                console.log("Call to REST completed: cuisines");
                res.send(o);
            }
            else {
                console.log("No value found");
                res.send({ "message": "no data" });
            }
        });
    }
    catch (e2) {
        console.log(e2);
    }
});
// start the express server
app.listen(port, () => {
    // tslint:disable-next-line:no-console
    console.log(`server started at http://${host}:${port}`);
});
