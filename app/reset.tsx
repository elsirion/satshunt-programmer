import { useLocalSearchParams } from "expo-router";
import React from "react";
import { ScrollView, Text } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import ResetBoltcard from "./components/ResetBoltcard";

export default function Reset() {
    const params = useLocalSearchParams();
    const url = params.url ? params.url.toString() : null;
    return (
        <SafeAreaView>
            <ScrollView>
                <Text style={{ fontSize: 20, fontWeight: "bold", margin: 10 }}>Reset Bolt Card</Text>
                <ResetBoltcard url={url} />
            </ScrollView>
        </SafeAreaView>
    );
}
