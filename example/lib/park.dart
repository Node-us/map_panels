import 'package:latlong/latlong.dart';

final parks = [
  Park(
    name: "Yushan National Park",
    lat: 23.4699986,
    lng: 120.9399454,
    imageUrl:
        "https://upload.wikimedia.org/wikipedia/commons/3/36/Mount_Yu_Shan_-_Taiwan.jpg",
    description:
        'The largest national park in Taiwan, located on the central part of the island. It is named after Mount Jade (Yushan literally means "Jade Mountain") which is the highest peak in East Asia at 3,952 metres.',
  ),
  Park(
      name: "Yangmingshan National Park",
      lat: 25.1558609,
      lng: 121.5215464,
      imageUrl:
          "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Xiao_You_Keng_Fumarole.jpg/150px-Xiao_You_Keng_Fumarole.jpg",
      description:
          'The northernmost national park on the island of Taiwan; it has a volcanic landform. Yangminshan is famous for its hotsprings and geothermal phenomenon. Each spring, Yangminshan also have a dazzling flower season. It is located partially in Taipei City and partially in New Taipei City.'),
  Park(
      name: "Taroko National Park",
      lat: 24.1941761,
      lng: 121.4893267,
      imageUrl:
          "https://assets.bucketlistly.blog/sites/5adf778b6eabcc00190b75b1/content_entry5adf77af6eabcc00190b75b6/5e29c5d54e4b61000cac3582/files/taroko-gorge-hualien-backpacking-itinerary-taiwan-main-image-op-thumb.jpg",
      description:
          'A magnificent marble gorge cut by Li-Wu River, creating one of the most astounding landscape in the world. It is also the home of the indigenous Truku people. Taroko is located in eastern Taiwan.'),
  Park(
      name: "Shei-Pa National Park",
      lat: 24.4491958,
      lng: 120.8767504,
      imageUrl:
          "https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Mt_Dabajian-winter_view.jpg/150px-Mt_Dabajian-winter_view.jpg",
      description:
          'Located in the central northern part of Taiwan island, in Hsinchu County and Miaoli County. It encompasses Xueshan (Snow Mountain), the second tallest mountain in Taiwan and East Asia, and Dabajian Mountain.'),
  Park(
      name: "Kinmen National Park",
      lat: 24.4441651,
      lng: 118.3503564,
      imageUrl:
          "https://eng.taiwan.net.tw/att/1/big_scenic_spots/pic_187_9.jpg",
      description:
          'Located on an island just off the coast of Mainland China, it includes famous historical battlefields in Kinmen. It is also known for its wetland ecosystem and traditional Fujian buildings that dated back to the Ming Dynasty.'),
  Park(
      name: "South Penghu Marine National Park",
      lat: 23.257615,
      lng: 119.6657534,
      imageUrl:
          "https://image.kkday.com/v2/image/get/w_1024%2Cc_fit%2Cq_55%2Ct_webp/s1.kkday.com/product_23914/20200527033642_qB7xK/jpg",
      description:
          'Located in the south of the Penghu Islands. The seas around the islets feature large clusters of Acropora coral and a diversity of fish and shells living among the reefs. The islets are also known for magnificent basalt terrains and unique low-roofed houses built by early inhabitants with coral stone and basalt.'),
  Park(
      name: "Taijiang National Park",
      lat: 23.00278,
      lng: 120.1354118,
      imageUrl:
          "https://eng.taiwan.net.tw/att/1/big_scenic_spots/pic_A12-00076_19.jpg",
      description:
          'Located in southwest Taiwan on the coast of Tainan City. The park\'s tidal landscape is one of its most distinctive features. Around 200 years ago, a large part of the park was part of the Taijiang Inland Sea. There is a rich variety of marine life, including 205 species of shellfish, 240 species of fish and 49 crab species that thrive on the marshes of southern Taiwan.'),
  Park(
    name: "Dongsha Atoll National Park",
    lat: 20.680507,
    lng: 116.839134,
    imageUrl:
        "https://np.cpami.gov.tw/images/com_fwgallery/files/516/Photo_FXF4S.jpg",
    description:
        'Taiwan\'s first marine national park. The atoll and the adjacent waters provide for a rich biodiversity of marine life from fish, jelly fish, squid, sicklefin lemon sharks, and rays to sea turtles, Dugongs, and cetaceans (dolphins and whales). Because strict protection is being taken, it is currently not open to public tourism.',
  ),
  Park(
    name: "Kenting National Park",
    lat: 21.9483307,
    lng: 120.7775629,
    imageUrl:
        'https://lh5.googleusercontent.com/p/AF1QipNSFnUmlFu0bmu-aDk3y85_Z4INPl3Fw1Cd2-ap=w408-h271-k-no',
    description:
        'Located on the southern tip of Taiwan, it is also the oldest national park on the Taiwan (Pingtung County), Kenting is famous for its tropical coral reef and migratory birds.',
  ),
];

class Park {
  String name;
  double lat;
  double lng;
  String imageUrl;
  String description;

  static List<Park> get taiwanParks => parks;

  LatLng get location => LatLng(lat, lng);

  Park({
    this.name,
    this.lat,
    this.lng,
    this.imageUrl,
    this.description,
  });
}
