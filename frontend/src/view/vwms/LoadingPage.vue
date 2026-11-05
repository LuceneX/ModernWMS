<!--
 @name : loading.vue
 @Description : 
 @author : saal
 @date : 2023/5/17
-->
<template>
  <div class="mask">
    <div class="loading-title">
      <div>LuceneX</div>
    </div>
    <div class="loading-progress-bar">
      <v-progress-linear
        :model-value="props.progress"
        color="primary"
        height="25"
        striped
      >
        <strong>{{ props.progress }}%</strong>
      </v-progress-linear>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  progress: {
    type: Number,
    required: true,
    default: 0
  }
})
</script>

<style scoped>
.mask {
  position: absolute;
  width: 100%;
  height: 100%;
  z-index: 1000;
  background-color: white;
  display: flex;
  align-items: center;
  flex-direction: column;
  justify-content: center;
}

.loading-progress-bar {
  width: 400px;
}

.loading-title {
  color: #c65a2e;
  font-weight: bold;
  font-size: 60px;
  margin-bottom: 20px;
}
</style>
