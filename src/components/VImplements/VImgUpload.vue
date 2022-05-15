<template>
  <!-- auto-upload -->
  <!-- action="//jsonplaceholder.typicode.com/posts/" -->
  <VueImgInputer
    :class="flat ? 'elevation-0' : ''"
    ref="vueImgInputer"
    v-model="file"
    icon="img"
    accept="image/*"
    :img-src="imgSrc"
    :max-size="maxSize"
    :on-start="onUploadStart"
    :on-progress="onUploadSProgress"
    :on-success="onUploadSuccess"
    :on-error="onUploadError"
    :no-hover-effect="readonly"
    :placeholder="`${placeholder}（maximun${maxMB}M）`"
    :readonly="readonly"
    readonly-tip-text=""
    :size="size"
    theme="material"
    @onExceed="overMaxSize"
    @onChange="fileChange"
  />
</template>

<script>
import 'vue-img-inputer/dist/index.css'
import VueImgInputer from 'vue-img-inputer'
import toast from '@/utils/toast'

export default {
  name: 'VImgUpload',
  components: {
    VueImgInputer,
  },
  props: {
    flat: {
      type: Boolean,
      default: false,
    },
    imgSrc: {
      type: String,
      default: '',
    },
    maxSize: {
      type: Number,
      default: 1024,
    },
    placeholder: {
      type: String,
      default: 'Click or drag to upload images',
    },
    readonly: {
      type: Boolean,
      default: false,
    },
    size: {
      type: String,
      default: 'normal',
      validator: size => ['small', 'normal', 'large'].includes(size),
    },
  },
  data: () => ({
    file: null,
  }),
  computed: {
    maxMB () {
      return this.maxSize / 1024
    },
  },
  methods: {
  /*** The file exceeds the specified size
     * Fired before fileChange

     * @param {File} e

     * @event

     */

    overMaxSize () {
      toast.error({ message: `Image size exceeds ${this.maxMB}mega` })
      this.reset()
      return
    },

    /**

     * select file

     * Triggered after overMaxSize

     * @param {File} e

     * @event

     */ fileChange (e) {
      if (!/image/.test(e.type)) {
        toast.error({ message: 'Upload a file that is not an image' })
        this.reset()
        return
      }
    },
    onUploadStart () {},
    onUploadSProgress () {},
    onUploadSuccess () {},
    onUploadError () {},
    reset () {
      this.file = null
      this.$refs['vueImgInputer'].reset()
      this.$refs['vueImgInputer'].$refs['inputer'].value = ''
    },
  },
}
</script>

<style lang="scss">
</style>
