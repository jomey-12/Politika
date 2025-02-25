import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:politika/models/news_model.dart';
import 'package:politika/pages/bookmarked_news_page.dart';
import 'package:politika/widgets/newsTile.dart';

import './detailed_news_page.dart';
import '../location_search_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NewsModel newsModel = new NewsModel();
  List newsList = [];
  Future getNews() async {
    String path = "https://politika-rest-api.herokuapp.com/";
    var uri = Uri.parse(path + 'news');
    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
    }).then((http.Response response) {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        newsList = jsonData;
        print(jsonData);
        return newsList;
      } else {
        print("failed");
      }
    }).catchError((onError) {
      print("error");
    });
  }

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Politika',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => BookmarkedNews()),
              );
            },
            icon: Icon(
              Icons.bookmark,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Center(
                //   child: searchBar(context),
                // ),
                SizedBox(
                  height: 50,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getNews(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Container(
                          child: ListView.builder(
                            itemCount: newsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              var exactdate =
                                  newsList[0]["date"].split("T").first;

                              DateTime newdate = DateTime.parse(exactdate);
                              String month = DateFormat.MMMM().format(newdate);
                              String day = exactdate.split("-").last;
                              String year = exactdate.split("-").first;
                              String reqDate = "$day $month, $year";

                              var exacttime =
                                  newsList[0]["date"].split("T").last;

                              var specifictime = exacttime.split(".").first;

                              var specific_time = specifictime.split(":");
                              var req_time =
                                  "${specific_time[0]}:${specific_time[1]}";

                              String am_pm;
                              String time_in_other_format;
                              if (int.parse(req_time.split(":").first) < 12) {
                                am_pm = "AM";
                                time_in_other_format = req_time;
                              } else {
                                am_pm = "PM";
                                time_in_other_format =
                                    (int.parse(req_time.split(":").first) - 12)
                                        .toString();
                              }
                              final final_req_time = "$time_in_other_format" +
                                  ":" +
                                  req_time.split(":").last +
                                  " " +
                                  am_pm;

                              NewsModel newsModel = new NewsModel();
                              print(newsModel);
                              newsModel.id = newsList[index]["id"];
                              newsModel.title = newsList[index]["title"];
                              newsModel.desc = newsList[index]["content"];
                              newsModel.location = newsList[index]["location"];
                              newsModel.date = reqDate;
                              newsModel.time = final_req_time;
                              newsModel.image = newsList[index]["image"];
                              newsModel.isBookmarked =
                                  newsList[index]["isBookmarked"];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: InkWell(
                                  child: newsTile(
                                    newsList[index]['title'],
                                    newsList[index]['content'],
                                    newsList[index]['image'],
                                    context,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            DetailedNews(
                                          newsModel: newsModel,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          LocationSearchBar(),
        ],
      ),
    );
  }
}

Widget searchBar(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.06,
    decoration: BoxDecoration(
      color: Color(0xFFF3F5FA),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Icon(
          Icons.search,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Search',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
