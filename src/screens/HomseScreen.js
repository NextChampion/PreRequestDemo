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

export default class HomseScreen extends Component {
  state = {
    list: [],
    loaded: false,
  };
  componentDidMount() {
    this.getData();
  }

  getData = async () => {
    const res = await getNews();
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
      return (
        <View style={styles.loading}>
          <ActivityIndicator />
        </View>
      );
    }
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
