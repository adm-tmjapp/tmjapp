
class RideHistory {
  final int ?id;
  final String ?name;
  final String? amount;
  final String ?time;

  const RideHistory({this.id, this.name, this.amount, this.time});

}

class RideHistoryList {
  static List<RideHistory> list() {
    const list = <RideHistory> [
      RideHistory(
        id: 1,
        name: 'Lucas Bookers',
        amount: '150',
        time: '1 day ago'
      ),
      RideHistory(
        id: 2,
        name: 'Martoon Park',
          amount: '49',
          time: '3 day ago'
      ),
      RideHistory(
        id: 3,
        name: 'London',
          amount: '149',
          time: '6 day ago'
      ),
      RideHistory(
        id: 4,
        name: 'Stadium Road',
          amount: '96',
          time: '11 day ago'
      ),
    ];
    return list;
  }
}