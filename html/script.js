window.addEventListener('message', function(event) {
    const data = event.data;
    const weaponHud = document.getElementById('weaponHud');
    const weaponIcon = document.getElementById('weaponIcon');
    const weaponName = document.getElementById('weaponName');
    const weaponClass = document.getElementById('weaponClass');
    const weaponAmmo = document.getElementById('weaponAmmo');

    if (data.type === 'updateWeaponHud') {
        if (data.show) {
            weaponHud.style.display = 'flex';
            weaponIcon.src = data.icon;
            weaponName.textContent = data.name;
            weaponClass.textContent = `Class: ${data.class}`;
            weaponAmmo.textContent = `Ammo: ${data.ammo}/${data.clipSize}`;
        } else {
            weaponHud.style.display = 'none';
        }
    }
});