using UnityEngine;

namespace Examples.BlackHole
{
    public class BlackHoleOrbiting : MonoBehaviour
    {
        [SerializeField] private float _speed = 1f;
        [SerializeField] private Transform _target;
        private float _angle;
        private Vector3 _originalOffset;

        private Transform _transform;

        private void Awake()
        {
            _transform = transform;
            _originalOffset = _target.position - _transform.position;
        }

        private void Update()
        {
            _angle += Time.deltaTime * _speed;
            _angle %= 360f;
            var offset = Quaternion.Euler(0, _angle, 0) * _originalOffset;
            _transform.position = _target.position - offset;
            _transform.forward = offset;
        }
    }
}