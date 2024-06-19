using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering.Universal;
using static RenderDepthOnly;

public class PerformaceTest : MonoBehaviour
{
    bool m_IsRequireDepth;
    public GameObject[] waves;
    void Start()
    {
        XRInputEvent.Instance.X += X;
        XRInputEvent.Instance.Y += Y;
        XRInputEvent.Instance.A += A;
        XRInputEvent.Instance.B += B;
    }

    void B(InputAction.CallbackContext context)
    {
        Camera.main.GetUniversalAdditionalCameraData().requiresDepthTexture = m_IsRequireDepth;
        m_IsRequireDepth = !m_IsRequireDepth;
    }

    void A(InputAction.CallbackContext context)
    {
        foreach (GameObject wave in waves)
        {
            wave.SetActive(!wave.activeInHierarchy);
        }
    }

    void Y(InputAction.CallbackContext context)
    {
        RenderDepthOnlyPass.isOpen = !RenderDepthOnlyPass.isOpen;
    }

    void X(InputAction.CallbackContext context)
    {

    }
}