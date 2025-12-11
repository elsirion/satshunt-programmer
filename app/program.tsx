import { useLocalSearchParams } from "expo-router";
import React from "react";
import { ScrollView, Text } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import SetupBoltcard from "./components/SetupBoltcard";

export default function ProgramBoltcardScreen() {
    const params = useLocalSearchParams();
    const url = params.url ? params.url.toString() : null;

    return (
        <SafeAreaView>
            <ScrollView>
                <Text style={{ fontSize: 20, fontWeight: "bold", margin: 10 }}>Program Bolt Card</Text>
                <SetupBoltcard url={url} />
            </ScrollView>
        </SafeAreaView>
    );
}
