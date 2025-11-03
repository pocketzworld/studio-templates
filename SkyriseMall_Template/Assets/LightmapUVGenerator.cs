using UnityEditor;
using UnityEngine;

public class LightmapUVGenerator : EditorWindow
{
    [MenuItem("Tools/Generate Lightmap UVs for Meshes")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(LightmapUVGenerator));
    }

    private void OnGUI()
    {
        if (GUILayout.Button("Generate Lightmap UVs"))
        {
            GenerateLightmapUVs();
        }
    }

    private void GenerateLightmapUVs()
    {
        string[] guids = AssetDatabase.FindAssets("t:Mesh", new[] { "Assets/Template" });

        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            ModelImporter modelImporter = AssetImporter.GetAtPath(path) as ModelImporter;

            if (modelImporter != null)
            {
                modelImporter.generateSecondaryUV = true;
                modelImporter.SaveAndReimport();
            }
        }

        Debug.Log("Lightmap UVs generated for all meshes in the folder.");
    }
}
