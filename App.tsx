import React, { useState } from "react";
import { NativeModules, SafeAreaView, ScrollView, StatusBar, StyleSheet, Text, useColorScheme, View, TextInput, Button } from 'react-native';

const { EmojiModule } = NativeModules;

function App(): React.JSX.Element {
  const [input, setInput] = useState("");
  const [output, setOutput] = useState({});

  const handleChangeText = async (text: any) => {
    text = text.trim().toLowerCase();
    setInput(text);
    console.log("input text:", text)
    try {
      const result = await EmojiModule.getEmoji(text);
      console.log("output: ", result)
      setOutput(result); 
    } catch (e) {
      console.error(e);
    }
  }

  return (
    <View style={styles.container}>
      {Object.entries(output).map(([emoji, score]) => (
        <View style={styles.row} key={emoji}>
          <Text style={styles.emoji}>{emoji}</Text>
          <Text style={styles.score}>{score as number}</Text>
        </View>
      ))}
      <TextInput 
        style={styles.input}
        value={input}
        onChangeText={text => setInput(text)}
        placeholder="Enter a Roll name" />
        <Button title="Get Emoji" onPress={() => handleChangeText(input)} />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 10,
    top: -50,
  },
  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 10,
  },
  emoji: {
    fontSize: 20,
  },
  score: {
    fontSize: 20,
  },
  input: {
    height: 40,
    width: 200,
    borderColor: 'gray',
    borderWidth: 1,
    marginBottom: 16,
    paddingLeft: 8,
  },
})

export default App;