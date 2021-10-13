import User = Realm.User;
import Realm from "realm";
import dotenv from "dotenv";
import path from "path";

import {RealmInterface, RealmServices} from "./modules/realm_module";

export {}


const express = require('express');

// for flutter use the cors is absolutely required
const cors = require('cors');

// initialize configuration
dotenv.config();
const id = String(process.env.REALM_ID);
// host and port are now available to the Node.js runtime
// as if it were an environment variable
const port = process.env.SERVER_PORT;
const host = process.env.HOST

const app = express();
let user: User;
// Configure Express to use EJS altough not needed for this project yet...
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");

// CORS is needed for the android and ios client
app.use(cors());

// define a route handler for the default home page
app.get("/", (req: any, res: any) => {
    // render the index template using ejs
    res.render("index");
});


const config = {
    id,
};
let realmService: RealmInterface;
const realm = new Realm.App(config);
// Use a Realm token for authentication kept in the .env
// an alternative would be to use the anonymous authentication
const key = String(process.env.API_KEY)
const credentials = Realm.Credentials.userApiKey(key);
const myPromise = new Promise<User>((resolve, reject) => {
    try {
        setTimeout(() => {
            resolve(realm.logIn(credentials));
        }, 3000);
    } catch (e) {
        reject("Login failed");
        console.log("Did not complete request for login");
    }
});

//  use the User object to initiate the RealmServices
const service: Promise<RealmServices> = new Promise((resolve, reject) => {
    try {
        myPromise.then((value: User) => {
            user = value;
            const _service = new RealmServices(user);
            realmService = _service;
            resolve(_service);
        }).catch(err => {
            console.log("Promise failed")
            reject(err);
        });
    } catch (err2: any) {
        console.log("error: ", err2);
    }
});

function getService(): RealmInterface  {
    if (realmService) return realmService;
    service.then((s: RealmServices) => {
        realmService = s;
    });
    return realmService;
}

//   byNeighborhood is exposed as a GET method.  It returns JSON
app.get("/byNeighborhood", (req: any, res: any) => {
    const neighborhood = req.query.name;
    const cuisines = req.query.cuisines ;
    try {
        let obj = getService().getByNeighborhood(neighborhood, cuisines );
        obj.then((o: object) => {
            if (o) {
                console.log("Call to REST completed: " + neighborhood + ' ' + cuisines);
                // Not needed but does give a visual indication of an http call successfully completing
                // console.log('Result: ' + JSON.stringify(o));
                res.send(o);
            } else {
                console.log("No value found")
                res.send({"message": "no data"})
            }
        });

    } catch (e2) {
        console.log(e2);
    }
});

app.get('/byCuisine', (req: any, res: any) => {
    const limit = req.query.limit;
    console.log( "Calling getRestaurantTypes");
    try {
        let obj: Promise<any> = getService().getRestaurantTypes(limit );
        obj.then((o: object) => {
            if (o) {
                console.log("Call to REST completed: cuisines");
                res.send(o);
            } else {
                console.log("No value found")
                res.send({"message": "no data"})
            }
        });
    } catch (e2) {
        console.log(e2);
    }
});


// start the express server
app.listen(port, () => {
    // tslint:disable-next-line:no-console
    console.log(`server started at http://${host}:${port}`);
});
