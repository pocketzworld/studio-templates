using UnityEngine;
using UnityEditor;

public class LightMultiplier : EditorWindow
{
    private float scaleFactor = 0.72f; // Change this factor according to your needs
    private float strengthFactor = 0.72f; // Change this factor according to your needs

    [MenuItem("Tools/Scale Lights")]
    static void Init()
    {
        LightMultiplier window = (LightMultiplier)EditorWindow.GetWindow(typeof(LightMultiplier));
        window.Show();
    }

    void OnGUI()
    {
        GUILayout.Label("Light Scaler", EditorStyles.boldLabel);

        scaleFactor = EditorGUILayout.FloatField("Scale Factor:", scaleFactor);
        strengthFactor = EditorGUILayout.FloatField("Strength Factor:", strengthFactor);

        if (GUILayout.Button("Scale Lights"))
        {
            ScaleLights();
        }
    }

    void ScaleLights()
    {
        Light[] lights = GameObject.FindObjectsOfType<Light>();

        foreach (Light light in lights)
        {
            if (light.type == LightType.Area)
            {
                // Scale the intensity
                light.intensity *= strengthFactor;

                // Scale the width and height for Area Lights
                light.areaSize *= scaleFactor;
            }
            else
            {
                // Scale the intensity for other light types
                light.intensity *= strengthFactor;
            }
        }

        Debug.Log("Lights scaled by factor: " + scaleFactor);
    }
}