/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  DeviceEventEmitter
} from 'react-native';
import Main from './components/Main.compoment';
import { AppTour, AppTourSequence, AppTourView } from 'onsensei-react-native-app-tour'

export default class App extends Component {

  constructor(props) {
    super(props);

    this.appTourTargets = [];
  }

  componentDidMount() {
    setTimeout(() => {
      let appTourSequence = new AppTourSequence();
      this.appTourTargets.forEach(appTourTarget => {
        appTourSequence.add(appTourTarget);
      });
      console.log(this.appTourTargets)
      AppTour.ShowSequence(appTourSequence);
    }, 1000);
  }

  render() {
    return (
      <View style={styles.container}>
        <Main style={styles.container}
        addAppTourTarget={appTourTarget => {
          this.appTourTargets.push(appTourTarget);
        }}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
});
