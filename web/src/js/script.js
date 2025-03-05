/**
 * Cambia el color del botón
 * @param {Node} btn - El nodo del botón en el DOM 
 * @returns {Node} El mismo nodo
 */
const btn = document.getElementById('changeColor')

const changeColor = (btn) => {
    btn.addEventListener('click', () => {
        btn.style.backgroundColor = 'green'
    })

    return btn
}

document.addEventListener('DOMContentLoaded', () => {changeColor(btn)})