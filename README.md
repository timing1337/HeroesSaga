# HeroesSaga
Lua files of the game Heroes Sage by EAGamebox and GOOD Mobile game

## Decryption method

```csharp
static void Main(string[] args)
{
    String path = @"D:/Data/";
    String key = "aaa";

    foreach (var file in Directory.EnumerateFiles(path, "*.*", SearchOption.AllDirectories))
    {
        String absolutePath = Path.Combine(path, file);
        byte[] data = File.ReadAllBytes(absolutePath);
        byte[] dst = new byte[data.Length - 5];
        Array.Copy(data, 5, dst, 0, dst.Length);
        byte[] res = XXTEA.Decrypt(dst, key);
        if (res == null) continue;
        File.WriteAllBytes(absolutePath, res);
    }
}
```
