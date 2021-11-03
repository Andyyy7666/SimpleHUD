-- Configure the loation display.
config = {
    display = {
        -- Nearby Postal display
        PostalScale = 0.40,
        PostalLocationX = 0.182,
        PostalLocationY = 0.912,

        -- Compass and street name display
        CompassStreetnameScale = 0.55,
        CompassStreetnameLocationX = 0.182,
        CompassStreetnameLocationY = 0.932,

        -- Time and Area display
        TimeScale = 0.40,
        TimeLocationX = 0.182,
        TimeLocationY = 0.96
    },

    -- Configure the voice range display.
    voiceRange = {
        enableVoiceRange = true,
        
        scale = 0.30,
        x = 0.163,
        y = 0.95,

        WhisperDistance = 2.0,
        NormalDistance = 10.0,
        ShoutingDistance = 30.0,
        
        enableBlueCirlce = true,
        Keybind = 20
    },
}
