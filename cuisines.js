/*
     This is the code for the REALM application
     @param - limit for infrequent cuisines - sort by occurrences
 */
exports = function(limit=5){

    let threshold = parseInt(limit);
    let pipeline = [{$group: {
            _id: "$cuisine",
            cnt: {
                $sum: 1
            }
        }}, {$match: {
            cnt: {$gt: threshold}
        }}, {$sort: {
            cnt: -1
        }}, {$project: {
            cnt:0
        }}]

    let collection = context.services.get("mongodb-atlas").db("sample_restaurants").collection("restaurants");

    let result = collection.aggregate(pipeline).toArray();

    return {result};
};
