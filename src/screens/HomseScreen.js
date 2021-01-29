import React, {Component} from 'react';
import {Text, View, StyleSheet} from 'react-native';
import {getNews} from '../serve';

export default class HomseScreen extends Component {
  componentDidMount() {
    this.getData();
  }

  getData = async () => {
    const result = await getNews();
    console.log('result==========', result);
  };
  render() {
    return (
      <View style={styles.container}>
        <Text> textInComponent </Text>
      </View>
    );
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'red',
    borderWidth: 1,
  },
});
