"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RealmServices = void 0;
class RealmServices {
    constructor(_user = "") {
        this.user = _user;
        console.log("loading service with user " + this.user.id);
    }
    async getRestaurantTypes(threshold) {
        console.log("getRestaurantTypes");
        try {
            return await this.user.callFunction("cuisines", [threshold]);
        }
        catch (e) {
            console.log("cuisines selection function failed", e);
        }
        return {};
    }
    async getByNeighborhood(neighborhood, cuisines) {
        try {
            console.log(`calling realm getByNeighborhood: ${neighborhood}   cuisines: ${cuisines} `);
            return await this.user.callFunction("restaurantsByNeighborhood", [neighborhood, cuisines]);
        }
        catch (e) {
            console.log("Call to Realm failed", e);
        }
        return {};
    }
}
exports.RealmServices = RealmServices;
