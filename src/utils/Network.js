import {NativeModules} from 'react-native';
const KSNetwork = NativeModules.KSNetwork;
KSNetwork.addEvent('Birthday Party', '4 Privet Drive, Surrey');

KSNetwork.addEventWithTime(
  'Birthday Party',
  '4 Privet Drive, Surrey',
  12345678,
); // 把日期以unix时间戳形式传递

KSNetwork.findEvents((error, events) => {
  console.log('events', events);
  //   if (error) {
  //     console.error(error);
  //   } else {
  //     this.setState({events: events});
  //   }
});

async function updateEvents() {
  try {
    const events = await KSNetwork.findEventsAsync();
    console.log('findEventsSync', events);
  } catch (e) {
    console.error(e);
  }
}

updateEvents();

class Network {
  async post(url, body) {
    console.log('url', url, body);
    const result = await KSNetwork.post(url, body);
    console.log('resultresultresultresult', result);
    return result;
  }
}
export default new Network();
