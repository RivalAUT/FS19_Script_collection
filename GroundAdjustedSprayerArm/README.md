# **GroundAdjustedSprayerArm**

## **Funktion**
Dieses Script fügt die Möglichkeit hinzu, 5 Kameras in einem HUD anzeigen zu lassen. 

Es gibt eine Automatik-Funktion, die bei bestimmten Ereignissen automatisch die Kamera wechselt:
- Beim Rückwärts-Fahren wird die Rückfahrkamera aktiviert
- Bei ausgefahrenem Abladerohr wird die Pipe-Kamera aktiviert

## **Einbau**
1. GroundAdjustedSprayerArm.lua in den Fahrzeugordner kopieren
2. Folgende Einträge in der modDesc hinzufügen:
````xml
<!-- in specializations: -->
<specialization name="groundAdjustedSprayerArm" className="GroundAdjustedSprayerArm" filename="scripts/GroundAdjustedSprayerArm.lua"/>
<!-- in vehicleTypes: -->
<specialization name="groundAdjustedSprayerArm"/>
<!-- Falls kein vehicleType vorhanden ist: -->
<type name="sprayerGroundAdjustedArms" parent="sprayer" filename="$dataS/scripts/vehicles/Vehicle.lua">
	<specialization name="groundAdjustedSprayerArm" />
</type>
````
3. In der i3d leere TransformGroups an den Stellen hinzufügen wo die Höhe vom Gestänge abgefragt/angepasst werden soll. Zudem eine TransformGroup in der Mitte (X Koordinate = 0) erstellen um einen Referenzwert der Höhe zu bekommen.
4. Folgenden Eintrag in der Fahrzeug xml hinzufügen:
````xml
<!-- Falls kein eigener vehicleType vorhanden war: vehicle type auf sprayerGroundAdjustedArms ändern -->
<vehicle type="sprayerGroundAdjustedArms">

<!-- Eintrag für Script: -->
<groundAdjustedSprayerArms arm1="0>0|0|0|0|0|0|0|0" arm2="0>0|0|0|0|1|0|0|0" arm1Raycast="0>0|0|0|0|0|0|0|0|0|0|6" arm2Raycast="0>0|0|0|0|1|0|0|0|0|0|6" midRaycast="0>0|0|0|0|11" foldMin="0" foldMax="0.01"/>
````
- `arm1` ist der Index zu einem der zwei Gestängeteile, z.B. das linke Gestänge. `arm2` ist das gleiche für den zweiten Gestängeteil. Diese Indizes werden ingame auf der Z-Achse rotiert um die Bodenanpassung zu ermöglichen. X und Y Rotationen müssen 0 sein.
- `arm1Raycast` ist der Index zum Raycast-Punkt vom `arm1`, also der Punkt wo die Höhe abgefragt wird. Analog dazu ist `arm2Raycast` der Punkt für `arm2`.
- `midRaycast` ist der Index zum Raycast-Punkt in der Mitte.
- `foldMin` und `foldMax` geben an bei welchem Klappzustand die Höhenanpassung funktionieren soll. Die Werte haben den Standardwert 0 (foldMin) und 1 (foldMax) wenn sie nicht angegeben werden.
