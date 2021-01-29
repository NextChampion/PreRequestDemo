import React from 'react';
import {View, Text, Image, StyleSheet} from 'react-native';

export default function ListItem(props) {
  const {data} = props || {};
  const {author_name, category, date, thumbnail_pic_s, title, uniquekey, url} =
    data || {};
  return (
    <View style={styles.container}>
      <Text>作者: {author_name}</Text>
      <Text>分类:{category} </Text>
      <Text>时间: {date}</Text>
      <Text>标题: {title}</Text>
      <Text>链接: {url}</Text>
      <Image source={{uri: thumbnail_pic_s}} />
      <Text>ListItem</Text>
    </View>
  );
}
const styles = StyleSheet.create({
  container: {
    borderBottomWidth: 1,
  },
});
