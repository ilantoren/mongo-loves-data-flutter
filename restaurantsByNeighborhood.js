/*
 *   REALM APPLICATION - FUNCTION
 *  restaurantsByNeighborhood
 *  @param  string neighborhood
* @param List<String> cuisines
 *  @returns object
 */

exports = function(neighborhood, _cuisines ){
    let cuisines = JSON.parse( _cuisines );

    // A simple function to create an average coordinate
    //  for centering the map.
    const avg = function( arr ) {
        let k = 0;
        let l = 1
        for( let j of arr) {
            k=k+j
            l=l+1
        }
        return k/l
    }


    // result is what is passed back
    let result = {}

    // aggregation pipeline for the neighborhood collection
    // this was taken from the Compass export to code menu for javascript
    let pipeline = [{$match: {
            name: neighborhood
        }}, {$project: {
            name:1,
            coord: {$arrayElemAt:["$geometry.coordinates", 0]},
            _id: 0
        }}, {$addFields: {
            long: {$map: {input: "$coord", in: {$arrayElemAt: ["$$this", 0]}}},
            lat: {$map: {input: "$coord", in: {$arrayElemAt: ["$$this", 1]}}}
        }}];
    // atlas specific - getting a db connection to the two collections: neighborhoods and restaurants
    let collection = context.services.get("mongodb-atlas").db("sample_restaurants").collection("neighborhoods");
    let restaurants = context.services.get("mongodb-atlas").db("sample_restaurants").collection("restaurants");

    class latlng {
        constructor( lat, lng ) {
            this.lat =lat;
            this.lng = lng;
        }
    }



    collection.aggregate( pipeline ).next().then( a  => {
        if (a ) {

            let query =  {$and: [
                    {"address.coord" : {$geoWithin: { $geometry: {type: "Polygon", coordinates: [a.coord]  }}}}]};


            if ( cuisines && cuisines.length > 0) {
                console.log( "Using cuisine ${cuisines}");
                query = {$and: [
                        {"address.coord" : {$geoWithin: { $geometry: {type: "Polygon", coordinates: [a.coord]  }}}},
                        {cuisine: {$in: cuisines}} ]};
            }

            // dart deserialization has a quirk with List<List<double>> fields.
            //One solution is to use js to map the data to a latlng type object
            let mycoords = a.coord.map( (a) => new latlng( a[1], a[0]));
            result.coord  = mycoords;
            let long = a.long;
            result.avg_long = avg( long );
            let lat = a.lat;
            result.avg_lat = avg( lat );
            result.name = a.name;
            const resultList =  restaurants.find( query ).toArray();
            result.restaurants = resultList;
            result.long = long;
            result.lat = lat;
        }
    });

    return result;
}
