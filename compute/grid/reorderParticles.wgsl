struct Particle {
    position: vec3f, 
    velocity: vec3f, 
    force: vec3f, 
    density: f32, 
    nearDensity: f32, 
}

@group(0) @binding(0) var<storage, read> sourceParticles: array<Particle>;
@group(0) @binding(1) var<storage, read_write> targetParticles: array<Particle>;
@group(0) @binding(2) var<storage, read> cellParticleCount : array<u32>;
@group(0) @binding(3) var<storage, read> particleCellOffset : array<u32>;

override xGrids: u32;
override yGrids: u32;
override gridCount: u32;
override cellSize: f32;
override xHalf: f32;
override yHalf: f32;
override zHalf: f32;
override offset: f32;

fn cellId(position: vec3f) -> u32 {
    let xi: u32 = u32(floor((position.x + xHalf + offset) / cellSize));
    let yi: u32 = u32(floor((position.y + yHalf + offset) / cellSize));
    let zi: u32 = u32(floor((position.z + zHalf + offset) / cellSize));

    return xi + yi * xGrids + zi * xGrids * yGrids;
}

@compute
@workgroup_size(64)
fn main(@builtin(global_invocation_id) id : vec3<u32>) {
    if (id.x < arrayLength(&sourceParticles)) {
        let cellId: u32 = cellId(sourceParticles[id.x].position);
        if (cellId < gridCount) {
            let targetIndex = cellParticleCount[cellId + 1] - particleCellOffset[id.x] - 1;
            if (targetIndex < arrayLength(&targetParticles)) {
                targetParticles[targetIndex] = sourceParticles[id.x];
            }
        }
    }
}