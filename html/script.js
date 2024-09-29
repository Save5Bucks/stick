window.addEventListener('message', function (event) {
    const data = event.data;
    const gearDisplay = document.getElementById('gear-display');
    // const rpmDisplay = document.getElementById('rpm-display');
    const fill = document.getElementById('tachometer-fill');
    const tach = document.getElementById('tachometer');
    const body = document.body;

    // Handle showing and hiding UI elements for both tachometer and gears
    if (data.type === "show") {
        // Show the entire UI for both tachometer and gear display
        gearDisplay.style.display = 'block';
        // rpmDisplay.style.display = 'block';
        body.style.display = 'block'; // Show the tachometer
        tach.style.display = 'block';
        fill.style.display = 'block';

        // Update the gear display
        gearDisplay.innerHTML = '';

        // Add Neutral (N) and Reverse (R) gears statically
        const reverseElement = document.createElement('span');
        reverseElement.classList.add('gear');
        reverseElement.textContent = 'R';
        if (data.currentGear === -1) {
            reverseElement.classList.add('reverse-active'); // Apply red color for reverse
        }
        gearDisplay.appendChild(reverseElement);

        const neutralElement = document.createElement('span');
        neutralElement.classList.add('gear');
        neutralElement.textContent = 'N';
        if (data.currentGear === 0) {
            neutralElement.classList.add('neutral-active'); // Apply orange color for neutral
        }
        gearDisplay.appendChild(neutralElement);

        // Populate gears dynamically based on maxGears
        const maxGears = data.maxGears || 5; // Default to 5 gears if not provided
        const currentGear = data.currentGear;

        for (let i = 1; i <= maxGears; i++) {
            const gearElement = document.createElement('span');
            gearElement.classList.add('gear');
            gearElement.textContent = i;
            if (i === currentGear) {
                gearElement.classList.add('active'); // Apply green color for the active gear
            }
            gearDisplay.appendChild(gearElement);
        }

        // Handle RPM updates (if any)
        if (data.rpm !== undefined) {
            const rpm = !isNaN(data.rpm) ? Number(data.rpm) : 0; // Ensure RPM is a valid number
            // rpmDisplay.innerText = `RPM: ${rpm.toFixed(0)}`;

            const percentage = Math.min(((rpm + 1000) / 10000) * 100, 100); // Scale RPM to 0-100%
            fill.style.width = percentage + '%';

            // Change color based on RPM percentage for tachometer
            if (percentage < 93) {
                fill.style.backgroundColor = 'white';
            } else if (percentage < 95) {
                fill.style.backgroundColor = 'green';
            } else {
                fill.style.backgroundColor = 'red';
            }
        }
    }

    if (data.type === "hide") {
        // Hide the entire UI
        gearDisplay.style.display = 'none';
        //rpmDisplay.style.display = 'none';
        tach.style.display = 'none';
        fill.style.display = 'none';
        body.style.display = 'none'; // Hide the tachometer
    }
});
