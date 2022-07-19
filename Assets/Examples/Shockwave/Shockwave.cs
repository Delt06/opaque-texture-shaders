using UnityEngine;

namespace Examples.Shockwave
{
    public class Shockwave : MonoBehaviour
    {
        private static readonly int ProgressId = Shader.PropertyToID("_Progress");

        public float MinProgress = -0.1f;
        public float MaxProgress = 1;
        public float Duration = 1f;

        public Renderer Renderer;
        private float _elapsedTime;

        private Material _material;

        private void Awake()
        {
            _material = Renderer.material;
        }


        private void Update()
        {
            _elapsedTime += Time.deltaTime;
            var t = _elapsedTime / Duration;
            var progress = Mathf.Lerp(MinProgress, MaxProgress, t);
            _material.SetFloat(ProgressId, progress);

            if (t >= 1)
                Destroy(gameObject);
        }

        private void OnDestroy()
        {
            if (_material != null)
                Destroy(_material);
        }
    }
}