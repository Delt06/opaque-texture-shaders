using UnityEngine;

namespace Examples.Shockwave
{
    public class ShockwaveSpawner : MonoBehaviour
    {
        public Shockwave ShockwavePrefab;
        public float Depth = 1f;

        private Camera _camera;

        private void Awake()
        {
            _camera = Camera.main;
        }

        private void Update()
        {
            if (!Input.GetMouseButtonDown(0)) return;

            var viewport = _camera.ScreenToViewportPoint(Input.mousePosition);
            viewport.z = Depth;
            var worldPoint = _camera.ViewportToWorldPoint(viewport);
            var cameraTransform = _camera.transform;
            Instantiate(ShockwavePrefab, worldPoint, cameraTransform.rotation, cameraTransform);
        }
    }
}