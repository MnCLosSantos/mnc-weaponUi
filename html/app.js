window.addEventListener("message", (event) => {
    let data = event.data;

    if (data.action === "show") {
        const ui = document.getElementById("weapon-ui");
        ui.classList.remove("hidden");
        document.getElementById("weapon-name").innerText = data.weapon;
        document.getElementById("weapon-ammo").innerText = "Ammo: " + data.ammo;
        document.getElementById("weapon-img").src = data.image;

        // Switch style
        document.getElementById("theme").setAttribute("href", `style${data.style}.css`);

        // Apply position/size
        ui.style.left = data.ui.x;
        ui.style.top = data.ui.y;
        ui.style.width = data.ui.width;
        ui.style.height = data.ui.height;

    } else if (data.action === "hide") {
        document.getElementById("weapon-ui").classList.add("hidden");
    }
});
