
class Notifications {
  final int? id;
  final String? title;
  final String? subtitle;
  final String ?time;

  const Notifications({this.id, this.title, this.subtitle, this.time});

}

class NotificationList {
  static List<Notifications> list() {
    const list = <Notifications> [
      Notifications(
        id: 1,
        title: '50% off all ride',
        subtitle: 'Lorem Ipsumhas been the industry sstandard available, but the majority have suffered ',
        time: '5 min ago'
      ),
      Notifications(
        id: 2,
        title: 'Change privacy',
          subtitle: 'Lorem Ipsumhas been the industry sstandard available, but the majority have suffered ',
          time: '21 min ago'
      ),
      Notifications(
        id: 3,
        title: 'You can earn',
          subtitle: 'Lorem Ipsumhas been the industry sstandard available, but the majority have suffered ',
          time: '6 hrs ago'
      ),
      Notifications(
        id: 4,
        title: '50% off all ride',
          subtitle: 'Lorem Ipsumhas been the industry sstandard available, but the majority have suffered ',
          time: '1 day ago'
      ),
    ];
    return list;
  }
}