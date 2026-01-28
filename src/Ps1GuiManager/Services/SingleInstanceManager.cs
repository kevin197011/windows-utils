using System;
using System.Threading;

namespace Ps1GuiManager.Services;

public static class SingleInstanceManager
{
    private static Mutex? _mutex;
    private const string MutexName = "PS1-GUI-Manager-SingleInstance";

    public static bool IsFirstInstance()
    {
        try
        {
            _mutex = new Mutex(true, MutexName, out bool createdNew);
            return createdNew;
        }
        catch
        {
            // If mutex creation fails, allow to continue
            return true;
        }
    }

    public static void Release()
    {
        _mutex?.ReleaseMutex();
        _mutex?.Dispose();
    }
}
