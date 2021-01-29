/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {SafeAreaView, StyleSheet, StatusBar} from 'react-native';

import HomseScreen from './screens/HomseScreen';

const App: () => React$Node = () => {
  return (
    <>
      <StatusBar barStyle="dark-content" />
      <SafeAreaView style={styles.container}>
        <HomseScreen />
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  container: {flex: 1},
});

export default App;
