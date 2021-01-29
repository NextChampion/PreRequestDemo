import React, {Component} from 'react';
import {
  Text,
  View,
  StyleSheet,
  FlatList,
  ActivityIndicator,
} from 'react-native';
import {getNews} from '../serve';
import ListItem from './ListItem';
import KSAbsoluteTime from '../utils/AbsoluteTime';
export default class HomseScreen extends Component {
  constructor(props) {
    super(props);
    this.state = {
      list: [],
      loaded: false,
    };
    KSAbsoluteTime.logCurrentTime('constructor');
  }

  componentDidMount() {
    this.getData();
  }

  getData = async () => {
    KSAbsoluteTime.logCurrentTime('请求数据开始');
    const res = await getNews();
    KSAbsoluteTime.logCurrentTime('请求数据结束');
    const {result} = res || {};
    const {data} = result || {};
    this.setState({list: data, loaded: true});
  };

  keyExtractor = (item) => item.uniquekey;

  renderItem = ({item}) => {
    return <ListItem data={item} />;
  };

  render() {
    const {list, loaded} = this.state;
    if (!loaded) {
      KSAbsoluteTime.logCurrentTime('loading页面初始化');
      return (
        <View style={styles.loading}>
          <ActivityIndicator />
        </View>
      );
    }
    KSAbsoluteTime.logCurrentTime('页面显示数据');
    return (
      <View style={styles.container}>
        <Text> textInComponent </Text>
        <FlatList
          data={list}
          renderItem={this.renderItem}
          keyExtractor={this.keyExtractor}
        />
      </View>
    );
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loading: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
