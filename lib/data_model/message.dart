class Message {
  final int? id;
  final String? type;
  final String ?name;
  final String? text;
  final String? time;

  const Message({this.id, this.type, this.name, this.text, this.time});
}

class MessageList {
  static List<Message> list () {
    const data = <Message> [
      Message(
        id: 1,
        text: 'hi',
        type: 'sender',
        name: 'Rockson Pular',
        time: '2.00 pm'
      ),
      Message(
          id: 2,
          text: 'hello',
          type: 'receiver',
          time: '2.05 pm'
      ),
      Message(
          id: 3,
          text: 'Where are u now?',
          type: 'sender',
          name: 'Rockson Pular',
          time: '2.10 pm'
      ),
      Message(
          id: 4,
          text: 'Park road , London paza . I will ',
          type: 'receiver',
          time: '2.15 pm'
      ),
      Message(
          id: 5,
          text: 'Thanks',
          type: 'sender',
          name: 'Rockson Pular',
          time: '2.16 pm'
      ),
      Message(
          id: 6,
          text: 'Eagerly waiting... ',
          type: 'receiver',
          time: '2.27 pm'
      ),
      Message(
          id: 7,
          text: 'Come to outside',
          type: 'sender',
          name: 'Rockson Pular',
          time: '2.30 pm'
      ),
      Message(
          id: 8,
          text: 'WOW! I am coming',
          type: 'receiver',
          time: '2.31 pm'
      ),

    ];
    return data;
  }
}