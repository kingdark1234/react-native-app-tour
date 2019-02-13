import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  TouchableHighlight
} from 'react-native';

import { AppTour, AppTourView } from 'onsensei-react-native-app-tour';

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
    'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

class Main extends Component {
  render() {
    return (
      <View style={styles.container}>
        <Text ref={ref => {
            this.text1 = ref;
            this.props.addAppTourTarget && this.props.addAppTourTarget(AppTourView.for(
                  ref,
                  { title: "This is a target Text 1",
                  description: "We have the best targets, believe me",
                  outerCircleColor: "#3f52ae" }
            ));
          }} style={styles.welcome}>Welcome to React Native!</Text>

        <Text ref={ref => {
            this.text2 = ref; 
            this.props.addAppTourTarget && this.props.addAppTourTarget(AppTourView.for(
                  ref,
                  { title: "This is a target Text 2",
                  description: "We have the best targets, believe me",
                  outerCircleColor: "#7051ae" }
            ));
          }} style={styles.instructions}>To get started, edit App.js</Text>

        <Text ref={ref => {
            this.text3 = ref;
            this.props.addAppTourTarget && this.props.addAppTourTarget(AppTourView.for(
                  ref,
                  { title: "This is a target Text 4",
                  description: "We have the best targets, believe me",
                  outerCircleColor: "#1f599e" }
            ));
          }} style={styles.instructions}>{instructions}</Text>

        <TouchableHighlight
          style={styles.button}
          ref={(ref) => {
            this.text4 = ref;
            this.props.addAppTourTarget && this.props.addAppTourTarget(AppTourView.for(
                  ref,
                  {title: "This is a target Button 1",
                  description: "We have the best targets, believe me",
                  outerCircleColor: "#af5bae"}
            ));
          }} onPress={() => {
            const targetView = AppTourView.for(this.text4, {
              title: 'Button!++++ๅ',
              description: 'Click Me !!!',
              outerCircleColor: '#123321',
              targetHolderColor: '#FFFFFF',
              transparentTarget: 'true',
              outerCircleAlpha: '1.0',
              targetRadius: '60',
              titleTextSize: '18',
              descriptionTextSize: '18',
              buttonText: 'OK',
              buttonTextSize: '18',
              buttonTextColor: '#FFFFFF',
              buttonBGColor: '#123FFF',
              buttonRadius: '10'
            });
            AppTour.ShowFor(targetView);}}>
          <Text> Click Me !!! </Text>
        </TouchableHighlight>

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
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  }, button: {
    alignItems: 'center',
    backgroundColor: '#DDDDDD',
    padding: 10
  }
});

export default Main;
