using System;
using static UnityEngine.InputSystem.InputAction;

public class XRInputEvent
{
    static XRInputEvent s_Instance;
    public static XRInputEvent Instance
    {
        get
        {
            if (s_Instance == null)
            {
                s_Instance = new XRInputEvent();
                s_Instance.Init();
            }
            return s_Instance;
        }
    }

    public Action<CallbackContext> X;
    public Action<CallbackContext> Y;
    public Action<CallbackContext> LeftTrigger;
    public Action<CallbackContext> LeftGrip;
    public Action<CallbackContext> A;
    public Action<CallbackContext> B;
    public Action<CallbackContext> RightTrigger;
    public Action<CallbackContext> RightGrip;

    XRInputActions m_Actions;
    void Init()
    {
        m_Actions = new XRInputActions();

        m_Actions.LeftHand.X.performed += context => X?.Invoke(context);
        m_Actions.LeftHand.Y.performed += context => Y?.Invoke(context);
        m_Actions.LeftHand.Trigger.performed += context => LeftTrigger?.Invoke(context);
        m_Actions.LeftHand.Grip.performed += context => LeftGrip?.Invoke(context);

        m_Actions.RightHand.A.performed += context => A?.Invoke(context);
        m_Actions.RightHand.B.performed += context => B?.Invoke(context);
        m_Actions.RightHand.Trigger.performed += context => RightTrigger?.Invoke(context);
        m_Actions.RightHand.Grip.performed += context => RightGrip?.Invoke(context);

        m_Actions.Enable();
    }
}