List<PathNode> smallRoute = [
  PathNode(
    longitude: -122.084,
    latitude: 37.4219983,
    accuracy: 5.0,
    altitude: 10.0,
    altitudeAccuracy: 2.0,
    heading: 90.0,
    headingAccuracy: 1.0,
    speed: 1.5,
    speedAccuracy: 0.2,
    timestamp: DateTime.parse("2024-12-14T10:00:00Z"),
    fillColor: "FF0000FF", // Red for the starting point
    pathNumber: 1,
    metadata: "Start of route",
  ),
  PathNode(
    longitude: -122.085,
    latitude: 37.4225,
    accuracy: 5.0,
    altitude: 12.0,
    altitudeAccuracy: 2.0,
    heading: 95.0,
    headingAccuracy: 1.0,
    speed: 1.8,
    speedAccuracy: 0.2,
    timestamp: DateTime.parse("2024-12-14T10:05:00Z"),
    fillColor: "00FF00FF", // Green for intermediate points
    pathNumber: 2,
    metadata: "Midpoint 1",
  ),
  PathNode(
    longitude: -122.086,
    latitude: 37.423,
    accuracy: 5.0,
    altitude: 15.0,
    altitudeAccuracy: 2.0,
    heading: 100.0,
    headingAccuracy: 1.0,
    speed: 2.0,
    speedAccuracy: 0.2,
    timestamp: DateTime.parse("2024-12-14T10:10:00Z"),
    fillColor: "00FF00FF", // Green for intermediate points
    pathNumber: 3,
    metadata: "Midpoint 2",
  ),
  PathNode(
    longitude: -122.087,
    latitude: 37.4235,
    accuracy: 5.0,
    altitude: 20.0,
    altitudeAccuracy: 2.0,
    heading: 105.0,
    headingAccuracy: 1.0,
    speed: 1.0,
    speedAccuracy: 0.2,
    timestamp: DateTime.parse("2024-12-14T10:15:00Z"),
    fillColor: "0000FFFF", // Blue for the endpoint
    pathNumber: 4,
    metadata: "End of route",
  ),
];



// await writeCsv("journey/This is my first book 123/pathnode.csv", smallRoute);
// await writeFile("journey/This is my first book 123/pathnode.csv", "");
// print(await readFile("journey/This is my first book 123/pathnode.csv"));
// var p = await readCsv("journey/This is my first book 123/pathnode.csv", (row) => PathNode.fromCsvRow(row));
// for(var p1 in p){
//   print(p1.toCsvRow());
// }



PageNode examplePageNode = PageNode(
  rows: RowMap(
    rows: {
      1: "Introduction to the journey.",
      2: "Details about the first scenic spot.",
      3: "Information about the valley view.",
    },
  ),
  pathNumber_1: 1, // Refers to the starting path node of this page
  pathNumber_2: 2, // Refers to the ending path node of this page
  t: 0.3, // Indicates the proportion along the edge between pathNumber_1 and pathNumber_2
  pageNumber: 1, // Unique identifier for the page
  metadata: "Page summarizing the highlights of the initial part of the journey.",
);

PageNode examplePageNode2 = PageNode(
  rows: RowMap(
    rows: {
      1: "Overview of the forest trail.",
      2: "Description of the nearby river crossing.",
      3: "Guide to the wildlife observation point.",
      4: "Cautions about slippery paths during rainy weather.",
    },
  ),
  pathNumber_1: 3, // Refers to the starting path node of this page
  pathNumber_2: 5, // Refers to the ending path node of this page
  t: 0.75, // Indicates the page is related to 75% along the edge from pathNumber_1 to pathNumber_2
  pageNumber: 2, // Unique identifier for this page
  metadata: "Page providing insights into the forest trail and its key attractions.",
);


await writeJson("journey/This is my first book 123/pagenode.json", [examplePageNode,examplePageNode2]);
print(await readFile("journey/This is my first book 123/pagenode.json"));



MediaNode exampleMediaNode = MediaNode(
  pathNumber_1: 1, // Start of the route
  pathNumber_2: 2, // First intermediate point
  t: 0.5, // Midway between path nodes 1 and 2
  medialLink: "https://www.shutterstock.com/image-vector/short-custom-urls-url-shortener-260nw-2233924609.jpg", // A web image link
  isMediaHttp: true, // Indicates the media link is an HTTP URL
  text: "A scenic view captured between points 1 and 2.",
  mediaNumber: 101, // Unique identifier for this media node
  metadata: "Photo of the valley view during the journey.",
);

await writeJson("journey/This is my first book 123/medianode.json", [exampleMediaNode]);
print(await readFile("journey/This is my first book 123/medianode.json"));


// await getDir("journey/This is my first book 123");
// await getFile("journey/This is my first book 123/pagenode.json");
// await getFile("journey/This is my first book 123/medianode.json");
// await deleteFile("journey/This is my first book 123/pagenode1.json");
// await deleteFile("journey/This is my first book 123/pagenode2.json");
// await deleteFile("journey/This is my first book 123/medianode1.json");

var p = await readJson("journey/This is my first book 123/pagenode.json",PageNode.fromJson);
for(var p1 in p){
  print(p1.toJson());
}
var q = await readJson("journey/This is my first book 123/medianode.json",MediaNode.fromJson);
for(var p1 in q){
  print(p1.toJson());
}


showModalBottomSheet(
  context: context,
  builder: (BuildContext context) {
    return Wrap(children: <Widget>[
      ListTile(
        title: const Text("Edit Media"),
        leading: const Icon(Icons.edit),
        onTap: (){

        },
      )
    ]);
  }
);