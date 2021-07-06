import 'package:flutter/material.dart';
import 'package:democoin/utils/Constants.dart';

class ChatInput extends StatefulWidget {
  final Function onPressed;

  ChatInput({this.onPressed});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String message;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: 120.0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,
              autofocus: false,
              textCapitalization:TextCapitalization.sentences ,
              decoration: InputDecoration(
                hintText: 'Please enter the message',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Theme.of(context).backgroundColor,
                enabledBorder: Constants.border,
                disabledBorder: Constants.border,
                border: Constants.border,
                errorBorder: Constants.border,
                focusedErrorBorder: Constants.border,
                focusedBorder: Constants.border,
              ),
              onChanged: (v) {
                message = v;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            child: RawMaterialButton(
              onPressed: () {
                setState(() {
                  widget.onPressed(message);
                  _controller.text = '';
                });
              },
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
              fillColor: Theme.of(context).accentColor,
              shape: CircleBorder(),
              elevation: 0.0,
            ),
            constraints: BoxConstraints(
              maxWidth: 40,
              maxHeight: 40,
            ),
          )
        ],
      ),
    );
  }
}
