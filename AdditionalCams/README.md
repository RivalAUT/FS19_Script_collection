# **AdditionalCams**

## **Funktion**
Dieses Script fügt die Möglichkeit hinzu, 5 Kameras in einem HUD anzeigen zu lassen. 

Es gibt eine Automatik-Funktion, die bei bestimmten Ereignissen automatisch die Kamera wechselt:
- Beim Rückwärts-Fahren wird die Rückfahrkamera aktiviert
- Bei ausgefahrenem Abladerohr wird die Pipe-Kamera aktiviert

## **Einbau**
1. AdditionalCams.lua und cam_hud.dds in den Fahrzeugordner kopieren
2. Folgende Einträge in der modDesc hinzufügen:
````xml
<!-- in specializations: -->
<specialization name="additionalCams" className="AdditionalCams" filename="AdditionalCams.lua" />
<!-- in vehicleTypes: -->
<specialization name="additionalCams" />
<!-- Falls kein vehicleType vorhanden ist: -->
<type name="combineDrivableAdditionalCams" parent="combineDrivable" filename="$dataS/scripts/vehicles/Vehicle.lua">
	<specialization name="additionalCams" />
</type>

<!-- Benötigte InputBindings/l10n: -->
<inputBinding>
	<actionBinding action="ACToggleMouse">
		<binding device="KB_MOUSE_DEFAULT" input="MOUSE_BUTTON_MIDDLE" />
	</actionBinding>
	<actionBinding action="ACMouseClick">
		<binding device="KB_MOUSE_DEFAULT" input="MOUSE_BUTTON_LEFT" />
	</actionBinding>
</inputBinding>

<actions>
	<action name="ACToggleMouse" category="VEHICLE" />
	<action name="ACMouseClick" category="VEHICLE" />
</actions>

<l10n>
	<text name="input_ACToggleMouse"><en>AdditionalCam: Toggle Mouse</en><de>AdditionalCam: Maus ein/ausblenden</de></text>
	<text name="input_ACMouseClick"><en>AdditionalCam: Mouse click</en><de>AdditionalCam: Maustaste</de></text>
</l10n>
````
3. Kameras in der i3d verbauen
4. Folgenden Eintrag in der Fahrzeug xml hinzufügen:
````xml
<!-- Falls kein eigener vehicleType vorhanden war: vehicle type auf combineDrivableAdditionalCams ändern -->
<vehicle type="combineDrivableAdditionalCams">

<!-- Einträge für Script: -->
<additionalCams>
	<cam node="rearCamera" position="reverse"/>
	<cam node="pipeCamera" position="pipe" />
	<cam node="attacherCamera" />
</additionalCams>
````
- `node` ist der Index zu der Kamera in der i3d
- `position` gibt an wo sich die Kamera befindet. Dies wird genutzt für die Automatik-Funktion. Es existieren nur die positions `"reverse"` und `"pipe"`
- Die Reihenfolge in der xml bestimmt die Reihenfolge ingame. Heißt: Der erste Eintrag ist Kamera 1, der zweite ist Kamera 2, usw.

5. Für Kameras in Anbaugeräten (Schneidwerken) kommt die AdditionalCutterCams ins Spiel. Diese fügt Kameras zu dem gefahrenen Fahrzeug hinzu (Voraussetzung: Fahrzeug muss mit AdditionalCams ausgerüstet sein).

Der Einbau gestaltet sich wie beim normalen Script:
````xml
<additionalCutterCams>
	<cam node="leftCamera"/>
	<cam node="rightCamera"/>
</additionalCutterCams>
````

## **BITTE BEACHTEN**
Bei aktivierter AdditionalCam kann es dazu kommen, dass die aktive Kamera (Standard First- oder Third-Person - nicht die Einblendung) verschwommen dargestellt wird.

Abhilfe dazu ist die AdditionalCam auszuschalten, die Kameras zu wechseln und dann die AdditionalCam wieder einzuschalten.

**Dies tritt auch bei Mitspielern im Multiplayer auf - das Script ist daher nur bedingt MP geeignet.**