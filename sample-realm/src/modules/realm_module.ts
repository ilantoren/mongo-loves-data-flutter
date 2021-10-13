

export interface RealmInterface {
     getRestaurantTypes( threshold: String ): Promise<any>;
     getByNeighborhood ( neighborhood: String , cuisines: String[]): Promise<any>;
}

export class RealmServices implements RealmInterface {
protected user: any;
constructor( _user: any = "") {
  this.user = _user;
  console.log( "loading service with user " + this.user.id );
 }

    public async getRestaurantTypes (threshold: String): Promise<any> {
    console.log( "getRestaurantTypes" );
        try {
            return await this.user.callFunction("cuisines", [threshold]);
        } catch (e: any) {
            console.log("cuisines selection function failed", e);
        }
        return {};
    }

   public  async getByNeighborhood ( neighborhood: String, cuisines: String[] ): Promise<any> {
      try {
          console.log(`calling realm getByNeighborhood: ${neighborhood}   cuisines: ${cuisines} `  );
          return await this.user.callFunction("restaurantsByNeighborhood", [neighborhood, cuisines]);
      } catch( e: any) {
          console.log("Call to Realm failed", e);
      }
      return {};
  }


}
