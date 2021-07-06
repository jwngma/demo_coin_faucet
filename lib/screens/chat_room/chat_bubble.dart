
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:democoin/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  ChatBubble(
      {@required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
            trailing: Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              child: CircleAvatar(
                radius: 20,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(message.uid == "Female"
                              ? "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT8t0Fi9Uv9I09kOArpDIhQ0mP6L0JZCvOeD--8S9wpwkbS4HCt&usqp=CAU"
                              : "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRaL54TKGYkzYRnXb6XAFOH9MCfk7DRdb2tZZcBAwZ4qIVG81X0&usqp=CAU"),
                          fit: BoxFit.fitHeight),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue)),
                ),
              ),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(0.0),
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        message.name,
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
                      ),

                      Divider(color: Colors.red,)
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Container(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0.0),
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                  )),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                  minHeight: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    message.message,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Container(
                        color: Colors.blueAccent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: Text(
                            "${DateFormat.yMMMMEEEEd().add_Hms().format(DateTime.parse(message.time))}",
                            style: TextStyle(fontSize: 8),
                          ),
                        ),
                      ),
                      Text(""),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
